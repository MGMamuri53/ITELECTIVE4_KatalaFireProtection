<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_projectBilling', function (Blueprint $table) {
            $table->bigIncrements('v_projectBillingId');

            $table->unsignedBigInteger('v_projectId');

            $table->string('v_billingNumber', 60)
                ->nullable()
                ->unique();

            $table->string('v_billingType', 50)
                ->nullable();

            $table->decimal('v_progressPercentage', 5, 2)
                ->nullable();

            $table->decimal('v_billingAmount', 14, 2);

            $table->dateTime('v_billingDate')
                ->nullable();

            $table->dateTime('v_dueDate')
                ->nullable();

            $table->string('v_billingStatus', 50)
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_projectId',
                'fk_projectBilling_project'
            )
                ->references('v_projectId')
                ->on('tbl_project')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_projectBilling');
    }
};